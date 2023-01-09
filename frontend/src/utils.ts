import { BigNumber, ethers } from 'ethers';
import { writable } from 'svelte/store';
import { FarmAbi, stakeAbi } from './abis';
import { env } from '$env/dynamic/public';


const farm_address = env.PUBLIC_FARM as string;
const stake_token = env.PUBLIC_STAKE as string;
const reward_token = env.PUBLIC_REWARD as string;

export const connected = writable(false);
export const data = writable(['0', '0']);
declare global {
	interface Window {
		ethereum: any;
	}
}

export const connect = async () => {
	if (typeof window.ethereum != 'undefined') {
		try {
			await window.ethereum.request({ method: 'eth_requestAccounts' });
			connected.set(true);
			const provider = new ethers.providers.Web3Provider(window.ethereum);
			const FarmContract = new ethers.Contract(farm_address, FarmAbi, provider);
			const pending: string = ethers.utils.formatUnits(
				await FarmContract.pendingRewards(window.ethereum.selectedAddress),
				18
			);
			const staked: string = ethers.utils.formatUnits(
				(await FarmContract.userInfo(window.ethereum.selectedAddress)).amount,
				18
			);
			data.set([staked, pending]);
		} catch (error) {
			console.log(error);
			connected.set(false);
		}
	} else {
		alert('Metamask not detected, please download metamask');
	}
};

const update = async () => {
	const provider = new ethers.providers.Web3Provider(window.ethereum);
	const FarmContract = new ethers.Contract(farm_address, FarmAbi, provider);
	const pending: string = ethers.utils.formatUnits(
		await FarmContract.pendingRewards(window.ethereum.selectedAddress),
		18
	);
	const staked: string = ethers.utils.formatUnits(
		(await FarmContract.userInfo(window.ethereum.selectedAddress)).amount,
		18
	);
	data.set([staked, pending]);
};

export const withdraw = async () => {
	const provider = new ethers.providers.Web3Provider(window.ethereum);
	const FarmContract = new ethers.Contract(farm_address, FarmAbi, provider);
	const signer = provider.getSigner();
	const FarmSigner = FarmContract.connect(signer);

	const amount = prompt('how much do you want to withdraw ?');
	const a = ethers.utils.parseUnits(amount as string, 18);
	await FarmSigner.withdraw(a);
	await update();
};

export const deposit = async () => {
	const provider = new ethers.providers.Web3Provider(window.ethereum);
	const FarmContract = new ethers.Contract(farm_address, FarmAbi, provider);
	const TokenContract = new ethers.Contract(stake_token, stakeAbi, provider);
	const signer = provider.getSigner();
	const FarmSigner = FarmContract.connect(signer);
	const TokenSigner = TokenContract.connect(signer);

	const amount = prompt('how much do you want to withdraw ?');
	const a = ethers.utils.parseUnits(amount as string, 18);

	await TokenSigner.approve(farm_address, a);
	await FarmSigner.deposit(a);
	await update();
};

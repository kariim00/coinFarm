<script>
	import { connect, connected, data, withdraw, deposit } from '../utils';
	let connectedValue = false;
	let values = ["", ""];
	connected.subscribe((v) => {
		connectedValue = v;
	});

	data.subscribe((v) => {
		values = v;
	});
</script>

<div class="main h-screen text-center pt-10 grid place-items-center">
	{#if !connectedValue}
		<button class="absolute right-5 top-5 bg-pink-200 py-2 px-4 rounded-xl" on:click={connect}
			>Connect</button
		>
	{:else}
		<button class="absolute right-5 top-5 bg-pink-400 py-2 px-4 rounded-xl" disabled
			>Connected</button
		>
	{/if}
	<div class="bg-slate-100 mx-auto w-1/4 h-1/2 my-auto pt-14 text-xl rounded-xl">
		<h1>Coin Farm</h1>
        {#if connectedValue}
        <h1>Staked coins: {values[0]}</h1>
		<h1>Pending rewards: {values[1]}</h1>
		<button class="bg-pink-800 text-white my-2 px-3 py-1 rounded-lg" on:click={withdraw}>
			Withdraw
		</button>
        <button class="bg-purple-800 text-white my-2 px-3 py-1 rounded-lg" on:click={deposit}>
			Deposit
		</button>
        {/if}
	</div>
</div>

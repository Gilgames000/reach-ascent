<script lang="ts">
    import Host from "./lib/components/Host.svelte";
    import Guest from "./lib/components/Guest.svelte";
    import {
        account,
        accountAddress,
        balance,
        connectWallet,
        symbol,
    } from "./lib/wallet";

    let userType: undefined | "host" | "guest";
</script>

<h1>Morra dApp</h1>

{#if $account}
    <hr />
    <div>
        <p>Address: {$accountAddress}</p>
        <p>Balance: {$balance} {$balance == "loading..." ? "" : symbol}</p>
    </div>
    <hr />
    {#if userType === "host"}
        <h3>Welcome host!</h3>
        <Host />
    {:else if userType === "guest"}
        <h3>Welcome guest!</h3>
        <Guest />
    {:else}
        <h3>Greetings traveler! Who are you?</h3>
        <button on:click={() => (userType = "host")}>Host</button>
        <button on:click={() => (userType = "guest")}>Guest</button>
    {/if}
{:else}
    <p>Please connect your wallet</p>
    <button on:click={connectWallet}>Connect Wallet</button>
{/if}

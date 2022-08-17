<script lang="ts">
    import FortuneTeller from "./lib/components/FortuneTeller.svelte";
    import Customer from "./lib/components/Customer.svelte";
    import {
        account,
        accountAddress,
        balance,
        connectWallet,
        symbol,
    } from "./lib/wallet";

    let userType: undefined | "teller" | "customer";
</script>

<h1>Fortune-telling dApp</h1>

{#if $account}
    <hr />
    <div>
        <p>Address: {$accountAddress}</p>
        <p>Balance: {$balance} {$balance == "loading..." ? "" : symbol}</p>
    </div>
    <hr />
    {#if userType === "teller"}
        <h3>Welcome fortune teller!</h3>
        <FortuneTeller />
    {:else if userType === "customer"}
        <h3>Welcome customer!</h3>
        <Customer />
    {:else}
        <h3>Greetings traveler! Who are you?</h3>
        <button on:click={() => (userType = "teller")}>Fortune teller</button>
        <button on:click={() => (userType = "customer")}>Customer</button>
    {/if}
{:else}
    <p>Please connect your wallet</p>
    <button on:click={connectWallet}>Connect Wallet</button>
{/if}

<script lang="ts">
    import { symbol } from "../wallet";
    import {
        tellerState,
        TellerState,
        initializeTeller,
        contractAddress,
    } from "../teller";

    let price: number;
    let fortune: string;
    let resolveFortune: (value: string | PromiseLike<string>) => void;

    function readFortune(): Promise<string> {
        if ($tellerState === TellerState.Idle) {
            $tellerState = TellerState.FortuneRequested;
        }

        return new Promise(
            (resolve) =>
                (resolveFortune = () => {
                    $tellerState = TellerState.FortunePending;
                    resolve(fortune);
                    fortune = "";
                })
        );
    }
</script>

{#if $tellerState === TellerState.NotInitialized}
    <p>What's the price of your fortunes?</p>
    <p><input type="number" bind:value={price} /> {symbol}</p>
    <button on:click={async () => await initializeTeller(price, readFortune)}
        >Confirm</button
    >
{:else if $tellerState === TellerState.Initializing}
    <p>
        Initializing the contract, please sign the requested transactions to
        proceed.
    </p>
{:else if $tellerState === TellerState.Idle}
    <p>Contract address: {$contractAddress}</p>
    <p>Waiting for someone to request a fortune...</p>
{:else if $tellerState === TellerState.FortuneRequested || $tellerState === TellerState.FortuneRejected}
    {#if $tellerState === TellerState.FortuneRejected}
        <p style="color:red; font-weight: bold;">
            Your fortune was rejected, tell another one.
        </p>
    {/if}
    <p>Tell a fortune:</p>
    <p><input type="text" bind:value={fortune} /></p>
    <button on:click={() => resolveFortune(fortune)}>Confirm</button>
{:else if $tellerState === TellerState.FortunePending}
    Waiting for the customer to either accept or reject your fortune...
{:else if $tellerState === TellerState.FortuneAccepted}
    <p>Congratulations, your fortune was accepted!</p>
{:else}
    <p>Something went wrong. Please refresh the page and try again.</p>
{/if}

<script lang="ts">
    import { symbol } from "../wallet";
    import {
        hostState,
        HostState,
        initializeHost,
        contractAddress,
        hasDrawHappened,
    } from "../host";

    let wager: number;
    let fingers: number = 0;
    let resolveFingers: (value: number | PromiseLike<number>) => void;
    let guess: number = 0;
    let resolveGuess: (value: number | PromiseLike<number>) => void;

    async function sleep(ms: number): Promise<void> {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    function getFingers(): Promise<number> {
        if ($hostState === HostState.Idle) {
            $hostState = HostState.ActionRequested;
        }

        return new Promise(
            (resolve) =>
                (resolveFingers = () => {
                    $hostState = HostState.ActionPending;
                    resolve(fingers);
                })
        );
    }

    function getGuess(): Promise<number> {
        if ($hostState === HostState.Idle) {
            $hostState = HostState.ActionRequested;
        }

        return new Promise(
            (resolve) =>
                (resolveGuess = () => {
                    $hostState = HostState.ActionPending;
                    resolve(guess);
                })
        );
    }
</script>

{#if $hasDrawHappened}
    <p style="color:red; font-weight: bold;">
        Last outcome was a draw! The game goes on.
    </p>
{/if}
{#if $hostState === HostState.NotInitialized}
    <p>What's the wager for this match?</p>
    <p><input type="number" bind:value={wager} /> {symbol}</p>
    <button
        on:click={async () => await initializeHost(wager, getFingers, getGuess)}
        >Confirm</button
    >
{:else if $hostState === HostState.Initializing}
    <p>
        Initializing the contract, please sign the requested transactions to
        proceed.
    </p>
{:else if $hostState === HostState.Idle}
    <p>Contract address: {$contractAddress}</p>
    <p>Waiting for a guest to connect...</p>
{:else if $hostState === HostState.ActionRequested}
    <p>How many fingers do you wanna play?</p>
    <input type="number" min="0" max="5" step="1" bind:value={fingers} />
    <p>What's your winning number guess?</p>
    <input type="number" min="0" max="10" step="1" bind:value={guess} />
    <p>
        <button
            on:click={async () => {
                resolveFingers(fingers);
                await sleep(1000);
                resolveGuess(guess);
                fingers = 0;
                guess = 0;
            }}>Confirm</button
        >
    </p>
{:else if $hostState === HostState.ActionPending}
    Waiting for the guest to play...
{:else if $hostState === HostState.MatchWon}
    <p>Congratulations, you won!</p>
{:else if $hostState === HostState.MatchLost}
    <p>Oh no, you lost...</p>
{:else}
    <p>Something went wrong. Please refresh the page and try again.</p>
{/if}

<script lang="ts">
    import {
        guestState,
        GuestState,
        attachGuest,
        hasDrawHappened,
    } from "../guest";

    let contractAddress: string;
    let fingers: number = 0;
    let resolveFingers: (value: number | PromiseLike<number>) => void;
    let guess: number = 0;
    let resolveGuess: (value: number | PromiseLike<number>) => void;

    async function sleep(ms: number): Promise<void> {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    function getFingers(): Promise<number> {
        if ($guestState === GuestState.ActionPending) {
            $guestState = GuestState.ActionRequested;
        }

        return new Promise(
            (resolve) =>
                (resolveFingers = () => {
                    $guestState = GuestState.ActionPending;
                    resolve(fingers);
                })
        );
    }

    function getGuess(): Promise<number> {
        if ($guestState === GuestState.ActionPending) {
            $guestState = GuestState.ActionRequested;
        }

        return new Promise(
            (resolve) =>
                (resolveGuess = () => {
                    $guestState = GuestState.ActionPending;
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
{#if $guestState === GuestState.NotAttached}
    <p>Enter the contract address of the Morra match:</p>
    <input type="text" bind:value={contractAddress} />
    <button
        on:click={async () =>
            await attachGuest(contractAddress, getFingers, getGuess)}
        >Confirm</button
    >
{:else if $guestState === GuestState.ActionRequested}
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
{:else if $guestState === GuestState.ActionPending}
    Waiting for the host to play...
{:else if $guestState === GuestState.MatchWon}
    <p>Congratulations, you won!</p>
{:else if $guestState === GuestState.MatchLost}
    <p>Oh no, you lost...</p>
{:else}
    <p>Something went wrong. Please refresh the page and try again.</p>
{/if}

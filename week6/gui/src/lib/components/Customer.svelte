<script lang="ts">
    import { customerState, CustomerState, attachCustomer } from "../customer";

    let contractAddress: string;
    let fortune: string;
    let resolveFortuneAcceptance: (
        value: boolean | PromiseLike<boolean>
    ) => void;

    function acceptFortune(_fortune: string): Promise<boolean> {
        fortune = _fortune;
        $customerState = CustomerState.FortuneAcceptancePending;
        return new Promise(
            (resolve) =>
                (resolveFortuneAcceptance = (_accepted) => {
                    if (_accepted) {
                        $customerState = CustomerState.FortuneAccepted;
                    } else {
                        $customerState = CustomerState.FortuneRequested;
                    }
                    resolve(_accepted);
                })
        );
    }
</script>

{#if $customerState === CustomerState.NotAttached}
    <p>Enter the contract address of the fortune teller:</p>
    <input type="text" bind:value={contractAddress} />
    <button
        on:click={async () =>
            await attachCustomer(contractAddress, acceptFortune)}
        >Confirm</button
    >
{:else if $customerState === CustomerState.RequestingFortune}
    <p>Please sign the transaction to request a fortune.</p>
{:else if $customerState === CustomerState.FortuneRequested}
    <p>Waiting for the fortune teller to read your fortune...</p>
{:else if $customerState === CustomerState.FortuneAcceptancePending}
    <p>Do you accept the following fortune?</p>
    <p>"{fortune}"</p>
    <div style="display: flex">
        <button on:click={() => resolveFortuneAcceptance(true)}>Yes</button>
        <button on:click={() => resolveFortuneAcceptance(false)}>No</button>
    </div>
{:else if $customerState === CustomerState.FortuneAccepted}
    <p>Congratulations, this is your fortune:</p>
    <p>"{fortune}"</p>
{:else}
    <p>Something went wrong. Please refresh the page and try again.</p>
{/if}

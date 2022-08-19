import { reach, account } from './wallet';
import * as backend from '../../backend/build/index.main.mjs';
import { get, writable } from 'svelte/store';


export enum HostState { NotInitialized, Initializing, Idle, ActionRequested, ActionPending, MatchWon, MatchLost };
export const hostState = writable(HostState.NotInitialized);
export const hasDrawHappened = writable(false);
export const contractAddress = writable(undefined);

export async function initializeHost(_wager: number, _getFingers: () => Promise<number>, _getGuess: () => Promise<number>) {
    hostState.set(HostState.Initializing);
    const contract = get(account).contract(backend);
    backend.HostPlayer(contract, {
        ...reach.hasRandom,
        wager: reach.parseCurrency(_wager),
        getFingers: _getFingers,
        getGuess: _getGuess,
        reportOutcome: (_outcome) => {
            if (_outcome == 0) {
                hostState.set(HostState.MatchWon);
                hasDrawHappened.set(false);
            } else if (_outcome == 1) {
                hasDrawHappened.set(true);
                hostState.set(HostState.ActionRequested);
            } else if (_outcome == 2) {
                hostState.set(HostState.MatchLost);
                hasDrawHappened.set(false);
            } else {
                console.error("Unknown outcome: " + _outcome);
            }
        },
        reportTimeout: () => alert("Timeout!"),
    });
    contractAddress.set(await contract.getInfo());
    hostState.set(HostState.Idle);
}

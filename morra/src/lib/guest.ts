import { account } from './wallet';
import * as backend from '../../backend/build/index.main.mjs';
import { get, writable } from 'svelte/store';
import { reach } from './wallet';


export enum GuestState { NotAttached, ActionRequested, ActionPending, MatchWon, MatchLost };
export const guestState = writable(GuestState.NotAttached);
export const hasDrawHappened = writable(false);
export const contractAddress = writable(undefined);

export async function attachGuest(_contractAddress: string, _getFingers: () => Promise<number>, _getGuess: () => Promise<number>) {
    const contract = get(account).contract(backend, reach.bigNumberify(_contractAddress));
    backend.GuestPlayer(contract, {
        ...reach.hasRandom,
        getFingers: _getFingers,
        getGuess: _getGuess,
        reportOutcome: (_outcome) => {
            if (_outcome == 0) {
                guestState.set(GuestState.MatchLost);
                hasDrawHappened.set(false);
            } else if (_outcome == 1) {
                hasDrawHappened.set(true);
                guestState.set(GuestState.ActionPending);
            } else if (_outcome == 2) {
                guestState.set(GuestState.MatchWon);
                hasDrawHappened.set(false);
            } else {
                console.error("Unknown outcome: " + _outcome);
            }
        },
        reportTimeout: () => alert("Timeout!"),
    });
    guestState.set(GuestState.ActionPending);
}

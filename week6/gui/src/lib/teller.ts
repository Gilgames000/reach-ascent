import { reach, account } from './wallet';
import * as backend from '../../backend/build/index.main.mjs';
import { get, writable } from 'svelte/store';


export enum TellerState { NotInitialized, Initializing, Idle, FortuneRequested, FortunePending, FortuneAccepted, FortuneRejected };
export const tellerState = writable(TellerState.NotInitialized);
export const contractAddress = writable(undefined);

export async function initializeTeller(_price: number, _readFortune: () => Promise<string>) {
    tellerState.set(TellerState.Initializing);
    const contract = get(account).contract(backend);
    backend.FortuneTeller(contract, {
        price: reach.parseCurrency(_price),
        readFortune: _readFortune,
        reportAcceptance: () => tellerState.set(TellerState.FortuneAccepted),
        reportRejection: () => tellerState.set(TellerState.FortuneRejected),
    });
    contractAddress.set(await contract.getInfo());
    tellerState.set(TellerState.Idle);
}

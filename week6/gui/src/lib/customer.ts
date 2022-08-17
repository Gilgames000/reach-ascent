import { account } from './wallet';
import * as backend from '../../backend/build/index.main.mjs';
import { get, writable } from 'svelte/store';
import { reach } from './wallet';


export enum CustomerState { NotAttached, RequestingFortune, FortuneRequested, FortuneAcceptancePending, FortuneAccepted };
export const customerState = writable(CustomerState.NotAttached);
export const contractAddress = writable(undefined);

export async function attachCustomer(_contractAddress: string, _acceptFortune: (_fortune: string) => Promise<boolean>) {
    const contract = get(account).contract(backend, reach.bigNumberify(_contractAddress));
    backend.Customer(contract, {
        requestFortune: () => customerState.set(CustomerState.FortuneRequested),
        acceptFortune: _acceptFortune,
    });
    customerState.set(CustomerState.RequestingFortune);
}

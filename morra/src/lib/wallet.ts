import { derived, writable, type Writable } from 'svelte/store';
import { loadStdlib } from '@reach-sh/stdlib';
import { ALGO_MyAlgoConnect as MyAlgoConnect } from '@reach-sh/stdlib';

export const providerEnv = 'TestNet';
export const network = 'ALGO';
export const symbol = 'ALGO';
export let reach = loadStdlib(network);

async function getBalance(_address: string) {
    return reach.formatCurrency(await reach.balanceOf(_address), 4);
}

export async function connectWallet() {
    delete (window as any).algorand;
    reach = loadStdlib(network);
    reach.setWalletFallback(
        reach.walletFallback({
            providerEnv,
            MyAlgoConnect,
        })
    );

    account.set(await reach.getDefaultAccount());
}

export const account: Writable<any> = writable(undefined);
export const accountAddress = derived(account, $account => $account?.networkAccount.addr);
export const balance = derived(accountAddress, ($accountAddress, set) => {
    if (!$accountAddress) {
        set('loading...');
        return;
    }
    const interval = setInterval(async () => {
        const balance = await getBalance($accountAddress);
        set(balance);
    }, 1000);
    return () => {
        clearInterval(interval);
    }
});


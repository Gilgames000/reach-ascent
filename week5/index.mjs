import { loadStdlib, ask } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';

async function getBalance(address) {
    return stdlib.formatCurrency(await stdlib.balanceOf(address), 4);
}

const stdlib = loadStdlib();
const startingBalance = stdlib.parseCurrency(100);

const accountAlice = await stdlib.newTestAccount(startingBalance);
const accountBob = await stdlib.newTestAccount(startingBalance);

const contractBob = accountBob.contract(backend);
const contractAlice = accountAlice.contract(backend, contractBob.getInfo());

await Promise.all([
    backend.Alice(contractAlice, {
        requestFortune: () => console.log('Alice requested a fortune'),
        acceptFortune: (fortune) => ask.ask(`Accept fortune: ${fortune}?`, ask.yesno),
    }),
    backend.Bob(contractBob, {
        price: stdlib.parseCurrency(1),
        readFortune: () => ask.ask('Tell a fortune:', (x) => x),
        reportAcceptance: () => console.log('Alice accepted the fortune'),
        reportRejection: () => console.log('Alice rejected the fortune'),
    }),
]);

ask.done();

console.log(`Alice's final balance: ${await getBalance(accountAlice)}`);
console.log(`Bob's final balance: ${await getBalance(accountBob)}`);

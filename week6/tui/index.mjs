import { loadStdlib, ask } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';

async function getBalance(address) {
    return stdlib.formatCurrency(await stdlib.balanceOf(address), 4);
}

const stdlib = loadStdlib();
const startingBalance = stdlib.parseCurrency(100);

const isAlice = await ask.ask('Are you Alice?', ask.yesno);

let account;
const wantsNewAccount = await ask.ask(
    'Would you like to create a devnet account?',
    ask.yesno
);

if (wantsNewAccount) {
    account = await stdlib.newTestAccount(startingBalance);
} else {
    const secret = await ask.ask(
        'What is your account secret?',
        (x => x)
    );
    account = await stdlib.newAccountFromSecret(secret);
}

console.log(`Your balance is ${await getBalance(account)}`);
let done;
if (isAlice) {
    const contractInfo = await ask.ask('Enter Bob\'s contract info:', (x) => x);
    const contract = account.contract(backend, contractInfo);

    done = backend.Alice(contract, {
        requestFortune: () => console.log('You requested a fortune'),
        acceptFortune: async (fortune) => await ask.ask(`Accept fortune: ${fortune}?`, ask.yesno),
    });
} else {
    const contract = account.contract(backend);

    done = backend.Bob(contract, {
        price: await ask.ask('What\'s the price of your fortunes?', (x) => stdlib.parseCurrency(x)),
        readFortune: async () => await ask.ask('Tell a fortune:', (x) => x),
        reportAcceptance: () => console.log('Alice accepted the fortune'),
        reportRejection: () => console.log('Alice rejected the fortune'),
    });

    console.log('The contract info is:', await contract.getInfo());
}

await done;
console.log(`Your final balance is ${await getBalance(account)}`);
ask.done();

### ***Code it***

Write an interact expression that binds the value to the result of interacting with Pat through the `getChallenge` method. Assign the expression to a `const` "challengePat"

Write an interact expression that binds the resulting value of interacting with Vanna through the `getChallenge` method. Assign the expression to a `const` "challengeVanna"

Write an interact expression that binds the value of `seePrice` for the `Bidder` participant. Assign the expression to a `const` "price"

Write an interact expression that binds the value of `getDescription` for the `Buyer` participant. Assign the expression to a `const` "description"
___
Add the declassify primitive to all the `interact` expressions above.
___
Add `.publish` statements to the `only` code blocks. .publish statements should follow the format of:_
``` rsh
PART.publish(const);
```
where PART is the participant and const is the constant assigned to the declassified interact value.

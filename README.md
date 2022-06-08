
# Connext Amarok contest details
- $71,250 USDC main award pot
- $3,750 USDC gas optimization award pot
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2022-06-connext-amarok-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts June 8, 2022 20:00 UTC
- Ends June 13, 2022 19:59 UTC

---

## Documentation

The most up-to-date contest information, protocol documentation, and other resources can be found [here](https://www.notion.so/connext/Contracts-Overview-eaf876ef16f3499d8cda8d131ba5199a).

### Scope

**Note:** While there are more contracts in this repo, the contracts within scope are in the `src/contracts/core` directory.

Reprinted from above documentation:

| File | sLoC | LoC | External Contracts Called | Libraries Used |
| --- | --- | --- | --- | --- |
| AssetFacet | 82 | 205 |  |  |
| BaseConnextFacet | 63 | 152 |  | LibDiamond, LibConnextStorage |
| BridgeFacet | 543 | 1,121 | Executor, TokenRegistry, Home, AavePool, StableSwap, SponsorVault, PromiseRouter | LibCrossDomainProperty, LibConnextStorage, TypedMemView |
| DiamondCutFacet | 29 | 49 |  | LibDiamond |
| DiamondLoupeFacet | 37 | 73 |  | LibDiamond |
| NomadFacet | 17 | 38 | XAppConnectionManager |  |
| PortalFacet | 93 | 194 | IAavePortal | AssetLogic |
| ProposedOwnableFacet | 132 | 298 |  | LibDiamond, LibConnextStorage |
| RelayerFacet | 75 | 177 | RelayerFeeRouter |  |
| RoutersFacet | 246 | 606 |  | AssetLogic, LibConnextStorage |
| StableSwapFacet | 226 | 505 | LPToken, Tokens | AmplificationUtils, SwapUtils |
| VersionFacet | 9 | 24 |  |  |
| DiamondInit | 44 | 82 |  | LibDiamond |
| ConnextPriceOracle | 143 | 180 | AggregatorV3Interface |  |
| ConnextProxyAdmin | 6 | 16 |  |  |
| Executor | 103 | 215 |  | ExcessivelySafeCall, LibCrossDomainProperty |
| LPToken | 23 | 53 |  |  |
| PriceOracle | 5 | 16 |  |  |
| ProposedOwnableUpgradeable | 149 | 333 |  |  |
| SponsorVault | 132 | 312 | ITokenExchange, IGasTokenOracle, BridgeFacet |  |
| StableSwap | 205 | 477 | LPToken | AmplificationUtils, SwapUtils |
| PromiseRouter | 132 | 316 | Home, Replica, BridgeFacet | PromiseMessage |
| RelayerFeeRouter | 62 | 169 | Home, Replica, BridgeFacet | RelayerFeeMessage |
| ProposedOwnable | 79 | 195 |  |  |
| File Total | 2635 | 5806 |  |  |
|  |  |  |  |  |
| Library | sLoC | LoC |  |  |
| AmplificationUtils | 64 | 122 |  |  |
| AssetLogic | 220 | 428 | IStableSwap, ITokenRegistry |  |
| ConnextMessage | 120 | 325 |  |  |
| LibConnextStorage | 96 | 319 |  |  |
| LibCrossDomainProperty | 58 | 161 |  |  |
| LibDiamond | 196 | 250 |  |  |
| MathUtils | 12 | 35 |  |  |
| SwapUtils | 618 | 1,066 |  |  |
| PromiseMessage | 72 | 166 |  |  |
| RelayerFeeMessage | 50 | 123 |  |  |
| Library Total | 1506 | 2995 |  |  |
| Total | 4141 | 8801 |  |  |


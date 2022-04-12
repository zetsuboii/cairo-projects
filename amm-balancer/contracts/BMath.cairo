%lang starknet

from starkware.cairo.common.uint256 import Uint256
from contracts.BNum import BNum

#	██████╗ ███╗   ███╗ █████╗ ████████╗██╗  ██╗
#	██╔══██╗████╗ ████║██╔══██╗╚══██╔══╝██║  ██║
#	██████╔╝██╔████╔██║███████║   ██║   ███████║
#	██╔══██╗██║╚██╔╝██║██╔══██║   ██║   ██╔══██║
#	██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║
#	╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
#   Balancer Math:
#   Includes functions that are used while calculating prices

namespace BMath:

    ################################################################################################
    # calcSpotPrice                                                                                #
    # sP = spotPrice                                                                               #
    # bI = tokenBalanceIn                ( bI / wI )         1                                     #
    # bO = tokenBalanceOut         sP =  -----------  #  ----------                                #
    # wI = tokenWeightIn                 ( bO / wO )     ( 1 - sF )                                #
    # wO = tokenWeightOut                                                                          #
    # sF = swapFee                                                                                 #
    ################################################################################################
    func calc_spot_price {range_check_ptr} (
        token_balance_in: Uint256,
        token_weight_in: Uint256,
        token_balance_out: Uint256,
        token_weight_out: Uint256,
        swap_fee: Uint256
    ) -> (
        spot_price: Uint256
    ):
        alloc_locals
        let (bone: Uint256) = BNum.b_one()

        let (local numer: Uint256) = BNum.div(token_balance_in, token_weight_in)
        let (local denom: Uint256) = BNum.div(token_balance_out, token_weight_out)
        let (local ratio: Uint256) = BNum.div(numer, denom)
        
        let (local fee_deducted: Uint256) = BNum.sub(bone, swap_fee)
        let (local scale: Uint256) = BNum.div(ratio, fee_deducted)
        
        return (spotPrice = BNum.mul(ratio, scale))
    end

    ################################################################################################
    # calcOutGivenIn                                                                               #
    # aO = tokenAmountOut                                                                          #
    # bO = tokenBalanceOut                                                                         #
    # bI = tokenBalanceIn              /      /            bI             \    (wI / wO) \         #
    # aI = tokenAmountIn    aO = bO # |  1 - | --------------------------  | ^            |        #
    # wI = tokenWeightIn               \      \ ( bI + ( aI # ( 1 - sF )) /              /         #
    # wO = tokenWeightOut                                                                          #
    # sF = swapFee                                                                                 #
    ################################################################################################
    func calc_out_given_in {range_check_ptr} (
        token_balance_in: Uint256,
        token_weight_in: Uint256,
        token_balance_out: Uint256,
        token_weight_out: Uint256,
        token_amount_in: Uint256,
        swap_fee: Uint256
    ) -> (
        token_amount_out: Uint256
    ):
        alloc_locals
        let (bone: Uint256) = BNum.b_one()

        let (local weight_ratio: Uint256) = BNum.div(token_weight_in, token_weight_out)
        let (local adjusted_in: Uint256) = BNum.sub(bone, swap_fee)
        let (local adjusted_token_in: Uint256) = BNum.mul(token_amount_in, adjusted_in)
        
        let (local after_in: Uint256) = BNum.add(token_balance_in, adjusted_in)
        # Balancer devs ran out of variable names upon this point 😭😭😭
        let (local y: Uint256) = BNum.div(token_balance_in, after_in)
        let (local foo: Uint256) = BNum.pow(y, weight_ratio)
        let (local bar: Uint256) = BNum.sub(bone, foo)

        return BNum.mul(token_balance_out, bar)
    end
end


local L0_1, L1_1, L2_1, L3_1, L4_1
L0_1 = GetPlayerServerId
L1_1 = PlayerId
L2_1 = msgpack
L2_1 = L2_1.pack
L3_1 = SetStateBagValue
function L4_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L3_2 = "player:%s"
  L4_2 = L3_2
  L3_2 = L3_2.format
  L5_2 = L0_1
  L6_2 = L1_1
  L6_2, L7_2, L8_2, L9_2, L10_2 = L6_2()
  L5_2, L6_2, L7_2, L8_2, L9_2, L10_2 = L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L4_2 = L2_1
  L5_2 = A1_2
  L4_2 = L4_2(L5_2)
  L5_2 = L3_1
  L6_2 = L3_2
  L7_2 = A0_2
  L8_2 = L4_2
  L10_2 = L4_2
  L9_2 = L4_2.len
  L9_2 = L9_2(L10_2)
  L10_2 = A2_2
  return L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
end
SetLocalStateValue = L4_1

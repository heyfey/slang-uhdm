`define PACK_INTN(VAR,SIZE) \
   begin \
     bits = { << int { VAR }}; \
     bits[SIZE-1:0] = { << 8 { bits[SIZE-1:0] }}; \
   end
`define UNPACK_INTN(VAR,SIZE) \
   begin \
     { << int { VAR }} = bits; \
   end

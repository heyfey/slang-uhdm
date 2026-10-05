`define UNPACK_ENUMN(VAR,SIZE,TYPE) \
   begin \
   if (packer.big_endian) \
     { << { VAR }} = packer.m_bits[packer.count +: SIZE];  \
   else \
     VAR = TYPE'(packer.m_bits[packer.count +: SIZE]); \
   \
   packer.count += SIZE; \
   end

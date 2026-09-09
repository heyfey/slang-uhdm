package p224;
   class C224;
      int x;
   endclass
endpackage

interface if224a();
   import p224::*;
   int    own_dyn224   [];
   int    own_fixed224 [3];
   int    own_plain224;
   C224   own_cls224;
   C224   own_clsdyn224 [];
   C224   own_clsfix224 [2];
endinterface

module top224;
endmodule

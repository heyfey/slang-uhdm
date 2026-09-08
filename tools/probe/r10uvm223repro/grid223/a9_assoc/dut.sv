package p223l;
   int    lv_assoc223 [string];
   int    lv_dyn223   [];
   int    lv_queue223 [$];
   int    lv_fixed223 [3];
endpackage

module m223l;
   import p223l::*;
   int ownml223;
endmodule

interface if223l();
   import p223l::*;
   int ownil223;
endinterface

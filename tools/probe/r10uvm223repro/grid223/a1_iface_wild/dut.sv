package p223a;
   int          pv_int223;
   string       pv_str223;
   bit [7:0]    pv_vec223;
   int          pv_arr223 [4];
   int          pv_assoc223 [string];
   typedef int  pt223;
   parameter    PP223 = 7;
   function automatic int pf223(); return 1; endfunction
endpackage

interface if223a();
   import p223a::*;
   int own223;
   initial begin
      own223 = 3;
   end
endinterface

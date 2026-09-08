// § ifaceOwnCallCalleeFormRoutes222 — ARM a4, THE EXACT CORPUS CALLEE KIND
// plus the two spellings the callee-form gate is the only thing that can
// separate: a receiver that is ITSELF A CALL, and an ESCAPED receiver name
// that CONTAINS a dot.  The callee here is a DPI-C import declared INSIDE the
// interface, exactly as `control_assertion_dpi` is at
// svaunit_vpi_interface.sv:40.
class obj22d;
   string p22d;
   function string path22d();
      return p22d;
   endfunction
endclass

interface if22d;
   import "DPI-C" context function void ctrl22d(input string a_name,
                                                input int a_kind,
                                                input int a_time);
   import "DPI-C" context function void stat22d(input string a_name,
                                                output int a_f,
                                                output int a_s);

   obj22d pool22d[4];

   // d01 DPI callee BARE, LITERAL argument (the svaunit 453/462/477/493 face).
   function void d01_lit(int a_t);
      ctrl22d("", 1, a_t);
   endfunction

   // d02 DPI callee BARE, RECEIVER-QUALIFIED CALL argument
   //     (the svaunit 310/334/358/383/408/434 face — THE HEAD).
   function void d02_recvarg(obj22d a_o, int a_t);
      ctrl22d(a_o.path22d(), 2, a_t);
   endfunction

   // d03 DPI callee BARE, indexed-receiver call argument, OUTPUT formals
   //     (the svaunit 512 face).
   function void d03_stat(int a_i);
      int f22d;
      int s22d;
      foreach (pool22d[k22d]) begin
         stat22d(pool22d[k22d].path22d(), f22d, s22d);
      end
   endfunction
endinterface

module toph22d;
   if22d u_if22d();
endmodule

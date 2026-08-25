// V6 — more shapes: name-RANGE members, parameterised base width, typedef
// base, nesting (do/forever/case/fork/labeled begin), inheritance, re-import
// chain, virtual class, and a 3-instance module.
package v6a;
   typedef enum { RA_A[3] }            ra_t;    // NAME RANGE
   typedef enum { RB_A[2:0] }          rb_t;    // NAME RANGE with bounds
   typedef enum int { RC_A[2] = 5 }    rc_t;    // NAME RANGE with a value
   typedef enum { RD_A, RD_B }         rd_t;    // control (no range)
   function ra_t g_ra(); return RA_A1; endfunction
   function rb_t g_rb(); return RB_A1; endfunction
   function rc_t g_rc(); return RC_A1; endfunction
   function rd_t g_rd(); return RD_B;  endfunction
endpackage

package v6b;
   parameter int W = 4;
   typedef bit [3:0] nib_t;
   typedef enum bit [W-1:0] { PA_A, PA_B }  pa_t;   // param-width base
   typedef enum nib_t       { PB_A, PB_B }  pb_t;   // typedef base
   function pa_t g_pa(); return PA_B; endfunction
   function pb_t g_pb(); return PB_B; endfunction
endpackage

package v6c;
   typedef enum { NA_A, NA_B, NA_C } na_t;
   function na_t n_do();     do return NA_A; while (0); endfunction
   function na_t n_forever(); forever return NA_A; endfunction
   function na_t n_case(bit c); case (c) 1'b0: return NA_B; default: return NA_C; endcase endfunction
   function na_t n_ifret(bit c); if (c) return NA_A; else return NA_B; endfunction
   function na_t n_lblbeg(); begin : lbl return NA_C; end endfunction
   function na_t n_while();  while (0) return NA_A; endfunction
   function na_t n_direct(); return NA_C; endfunction        // control: FOLDS
endpackage

package v6d;
   import v6c::*;
   export v6c::*;
endpackage
package v6e;
   import v6c::*;
   function v6c::na_t g_chain(); return NA_B; endfunction     // re-export chain
endpackage

package v6f;
   typedef enum { VA_A, VA_B } va_t;
   virtual class VC;
      pure virtual function va_t pv();
      extern function va_t cv();
   endclass
   function va_t VC::cv(); return VA_B; endfunction
   class DC extends VC;
      virtual function va_t pv(); return VA_A; endfunction    // in-body: no fold
      extern function va_t ov();
   endclass
   function va_t DC::ov(); return VA_A; endfunction
endpackage

module v6mod;
   v6f::va_t a;
   initial a = v6f::VA_A;
endmodule

module v6top;
   v6mod m1(), m2(), m3();
   v6a::ra_t ra; v6a::rb_t rb; v6a::rc_t rc; v6a::rd_t rd;
   v6b::pa_t pa; v6b::pb_t pb; v6c::na_t na; v6f::va_t va;
   v6f::DC dc;
   initial begin
      ra = v6a::g_ra(); rb = v6a::g_rb(); rc = v6a::g_rc(); rd = v6a::g_rd();
      pa = v6b::g_pa(); pb = v6b::g_pb();
      na = v6c::n_do(); na = v6c::n_case(0); na = v6c::n_lblbeg();
      na = v6c::n_while(); na = v6c::n_direct(); na = v6c::n_ifret(1);
      na = v6e::g_chain();
      dc = new(); va = dc.pv(); va = dc.cv(); va = dc.ov();
   end
endmodule

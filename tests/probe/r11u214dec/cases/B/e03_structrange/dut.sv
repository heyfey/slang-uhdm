// § modStructMemberQualSpan214 — a module-local packed struct typedef whose member range folds a package parameter (Earlgrey tlul_adapter_sram.sv:56)
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  typedef enum logic [7:0] { Data0 = 8'h04, Data1 = 8'h05 } dm_csr_e;
endpackage
package top_pkg;
  localparam int TL_DBW = 4;
  localparam int TL_SZW = $clog2($clog2(TL_DBW)+1);
endpackage
module m(output logic [7:0] o);
  typedef struct packed {
    logic                       error;
    logic [top_pkg::TL_SZW-1:0] size;
  } req_t;
  req_t r;
  assign r = '0;
  assign o = 8'(r);
endmodule
module top(output logic [7:0] o);
  m u(.o(o));
endmodule

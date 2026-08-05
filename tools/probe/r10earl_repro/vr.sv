// vr.sv — pass 13.  § shadowedImportBoundFold ONE LEVEL OUT: 5 Earlgrey heads.
//   rstmgr_ctrl.sv:12:31  `localparam int OffDomains = PowerDomains - 1` (x2)
//   flash_mp.sv:14:33     `localparam int TotalRegions = MpRegions+1`
//   flash_erase_ctrl:41:20 `localparam logic[AddrW-1:0] PageAddrMask = ...`
//   usbdev.sv:245:25      `for (int i = 0; i < NEndpoints; i++)`
// Every one of the five modules declares its OWN parameter/localparam of that
// name AND wildcard-imports a package that declares the same name; Surelog's
// name-keyed getValue finds the PACKAGE member, so the read is already valued
// when the def is compiled and folds — while slang's Lookup finds the module
// declaration and we keep a ref_obj.  flash_erase_ctrl is the DECISIVE row:
// its own `parameter int AddrW = 10` and flash_ctrl_pkg's `AddrW` differ (10
// vs 17) and golden folds **17**, so the package member is not merely a
// tie-break — it WINS.  Note the import sits in the module BODY, AFTER the
// parameter port list, in three of the five.
//
// Rows:  A  port-list localparam init, ARITH, shadowed name
//        B  port-list localparam init, PLAIN, shadowed name
//        C  body localparam init, ARITH, shadowed name
//        D  a localparam's DECLARED-TYPE range bound, shadowed name
//        E  a for-loop bound, shadowed name
//        N1 the same shapes on an UNSHADOWED module parameter (must NOT fold)
package vrp;
  localparam int PW = 17;
  localparam int NE = 12;
  localparam int NC = PW - 1;     // COMPUTED init (rstmgr_pkg::OffDomains)
endpackage

module vra #(
  parameter int PW = 10,          // shadowed by vrp::PW = 17
  parameter int MW = 3,           // NOT shadowed
  localparam int A = PW - 1,      // A  port-list, ARITH   -> golden 16
  localparam int B = PW,          // B  port-list, PLAIN   -> golden 17
  localparam int N1 = MW - 1      // N1 negative control   -> stays symbolic
) (
  input  logic [MW-1:0] d_i,
  output logic          o
);
  import vrp::*;
  localparam int NE = 4;          // shadowed by vrp::NE = 12
  localparam int C = NE + 1;      // C  body localparam, ARITH -> golden 13
  localparam int F = $clog2(NE);  // F  SYS-FUNC-CALL argument (flash_mp:15,
                                  //    flash_erase_ctrl:31) -> golden arg 12
  localparam logic [PW-1:0] D = '1;   // D  declared-type bound -> golden 17
  localparam int LL = 5;          // unshadowed body localparam
  // H rows: a NET's declared-type bound in the def view (rstmgr_ctrl.sv:31
  // `logic [OffDomains-1:0] rst_pd_n`, where golden's substituted leaf is an
  // INT const ct7 and ours a UINT ct9).
  logic [NE-1:0] hn;              // H1 shadowed name
  logic [MW-1:0] hm;              // H2 module PARAMETER port (control)
  logic [LL-1:0] hl;              // H3 unshadowed module localparam (control)
  localparam int NC = 2;          // shadows vrp::NC, whose init is COMPUTED
  logic [NC-1:0] hc;              // H4 shadowed name, COMPUTED package init
  int cnt;
  int e2, e3;
  always_comb begin
    cnt = 0;
    for (int i = 0; i < NE; i++)  // E1 for-loop bound -> golden 12?
      cnt = cnt + 1;
    e2 = NE + 1;                  // E2 plain procedural read
  end
  assign e3 = NE - 1;             // E3 continuous-assign read
  assign o = (|d_i) & (A != 0) & (B != 0) & (C != 0) & (N1 != 0) & (|D)
           & (cnt != 0) & (e2 != 0) & (e3 != 0) & (F != 0)
           & (|hn) & (|hm) & (|hl) & (|hc);
endmodule

module vrtop;
  logic [2:0] d;
  logic o;
  vra u1 (.d_i(d), .o(o));
endmodule

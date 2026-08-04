// r10rggen9 t8: a module port whose ACTUAL is `<interface_instance>.<signal>`.
// rggen_register_common:44 `.i_address (register_if.address)` — golden's
// vpiHighConn is the INTERFACE VARIABLE OBJECT itself (a logic_var named
// `address`, located at the interface's declaration 10:29 and re-fullnamed
// `<inst>.i_address.address`), not the hier_path we emit.  Siblings pin what
// the rule needs: a plain net actual, a SELECT of an interface signal, an
// interface signal read from a MODPORT-typed port, an enum-typed signal, and
// a whole-interface port.
interface ifc;
  logic         valid;
  logic [7:0]   address;
  logic [7:0]   data;
  modport mp (input valid, input address, output data);
endinterface

module leaf (
  input  logic       i_valid,
  input  logic [7:0] i_addr,
  input  logic [3:0] i_half,
  input  logic       i_plain,
  output logic [7:0] o_data
);
  assign o_data = {7'b0, i_valid & i_plain} + {4'b0, i_half} + i_addr;
endmodule

module mid (ifc.mp mif, input logic p);
  logic [7:0] w;
  // an interface signal reached through a MODPORT-typed port
  leaf u_leaf2 (
    .i_valid  (mif.valid    ),
    .i_addr   (mif.address  ),
    .i_half   (mif.address[3:0]),
    .i_plain  (p            ),
    .o_data   (w            )
  );
  assign mif.data = w;
endmodule

module top (input logic clk, output logic [7:0] o);
  ifc         u_if ();
  logic       plain;
  logic [7:0] d0;

  assign plain    = clk;
  assign u_if.valid   = clk;
  assign u_if.address = 8'h5a;

  // the Rggen shape: instance-qualified interface signals
  leaf u_leaf (
    .i_valid  (u_if.valid       ),
    .i_addr   (u_if.address     ),
    .i_half   (u_if.address[3:0]),
    .i_plain  (plain            ),
    .o_data   (d0               )
  );

  mid u_mid (.mif(u_if), .p(plain));

  assign o = d0 + u_if.data;
endmodule

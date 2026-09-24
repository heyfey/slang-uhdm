// r10earl8 witness tj — DEF-VIEW GEN-BLOCK hier_path components that carry a
// BIT SELECT.  Census class (4 AllModules heads, tied biggest at pass-8 entry):
//   bit_select 'alert_cause' alert_handler_reg_wrap.sv:105:19
//     vs  ref_obj 'alert_cause[k]' :105:19
//   bit_select 'q'                 gpio.sv:40:47   vs ref_obj 'q[i]' :40:45
//   bit_select 'dio_pads'          padctrl.sv:100:19
//   bit_select 'mio_out_sleep_val' pinmux.sv:95:41
// i.e. golden names the COMPONENT and hangs the index off it; we emit one
// ref_obj literally NAMED "<component>[<index>]".
package tjp;
  typedef struct packed {
    logic d;
    logic de;
  } fld_t;
  typedef struct packed {
    fld_t [3:0] cause;
    fld_t       one;
  } h2r_t;
endpackage

module tjsub (
  input  logic a_i,
  output logic z_o
);
  assign z_o = ~a_i;
endmodule

module tj
  import tjp::*;
(
  input  h2r_t        r2h_i,
  output h2r_t        h2r_o,
  input  logic [3:0]  v_i,
  output logic [3:0]  z_o
);

  for (genvar k = 0; k < 4; k++) begin : gen_a
    // A — select on a MIDDLE component (alert_handler_reg_wrap / padctrl /
    //     pinmux shape)
    assign h2r_o.cause[k].d = 1'b1;
    // B — select on the LAST component
    assign z_o[k] = r2h_i.cause[k].d;
    // C — a PLAIN (undotted) select control
    assign h2r_o.one.d = v_i[k];
    // D — the same dotted+selected shape as a PORT ACTUAL (gpio shape)
    tjsub u_sub (
      .a_i(r2h_i.cause[k].de),
      .z_o()
    );
  end

  // E — module-scope control: the same paths outside any gen block
  assign h2r_o.one.de = r2h_i.cause[0].d;

endmodule

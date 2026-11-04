// § defGenCfcThroughCondSel255 (a path as the index of a select, no ?:)
package pp;
  typedef struct packed { logic [3:0] q; } padsel_t;
  typedef struct packed { padsel_t [1:0] wkup_detector_padsel; logic [1:0] en; } reg2hw_t;
endpackage
module pinmux (input pp::reg2hw_t reg2hw, input logic [15:0] dio_data_mux, input logic [15:0] mio_data_mux, output logic [1:0] o);
  for (genvar k = 0; k < 2; k++) begin : gen_wkup_detect
    logic pin_value;
    assign pin_value = dio_data_mux[reg2hw.wkup_detector_padsel[k]];
    assign o[k] = pin_value;
  end
endmodule
module top;
  pp::reg2hw_t r;
  logic [1:0] o;
  pinmux u (.reg2hw(r), .dio_data_mux(16'h0), .mio_data_mux(16'h0), .o(o));
endmodule

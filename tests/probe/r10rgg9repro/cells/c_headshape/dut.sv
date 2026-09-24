interface reg_if;
  logic [31:0] write_data;
  modport register (input write_data);
endinterface
module m #(
  parameter bit WRITABLE = 1,
  parameter int WORDS = 1
)(reg_if.register register_if);
  logic [31:0] write_data[2];
  assign write_data[0] = (WRITABLE) ? {WORDS{register_if.write_data}} : '0;
endmodule
module top;
  reg_if ri();
  m #(.WRITABLE(0)) u_a(.register_if(ri));
  m #(.WRITABLE(1)) u_b(.register_if(ri));
endmodule

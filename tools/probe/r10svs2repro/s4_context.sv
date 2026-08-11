// r10svs2 ARM s4 — the member-select CONTEXT.  The brief's explicit warning:
// golden may span the hier_path differently per context.  Every context SVSwitch
// actually uses is here, one per line, parens-less.
class cx;
  rand int r_len;
  rand byte data[];      // `rand`, exactly like SVSwitch Packet.sv:23, so that
                         // `solve data.size before r_len` is legal (slang: "target
                         // of 'solve before' constraint must be a random variable")
  logic [7:0] bytes[];

  function int f();
    int i, r;
    // (1) for-CONDITION  (the witness, Packet.sv:48)
    for (i = 0; i < data.size; i++) r = r + 1;
    // (2) INDEX expression (Packet.sv:86, :91 / Receiver.sv:41)
    r = bytes[bytes.size - 1];
    // (3) plain RVALUE of an assignment (Packet.sv:78)
    r = bytes.size;
    // (4) `new[...]` SIZE argument (Packet.sv:71, :87)
    bytes = new[data.size + 4];
    // (5) a $display ARGUMENT (Receiver.sv:46)
    $display("%0d", bytes.size);
    // (6) a BINARY-OP operand at top level of a condition
    if (data.size > 3) r = r + 1;
    return r;
  endfunction

  // (7) CONSTRAINT expression (Packet.sv:28/31/32/34, testcase.sv:14)
  constraint c_size { data.size inside {[1:250]}; }
  constraint c_rel  { r_len == data.size; }
  constraint c_add  { r_len == data.size + 2; }
  constraint c_slv  { solve data.size before r_len; }
endclass

module top;
  cx o;
  initial begin
    o = new();
    $display("%0d", o.f());
  end
endmodule

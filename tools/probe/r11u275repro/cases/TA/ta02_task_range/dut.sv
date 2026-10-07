// § tfLocalArrRangeDimEnd275 — a ranged unpacked local in a module task
module dut (output logic [7:0] o);
  task automatic t(output logic [7:0] r);
    logic [7:0] m [3:0];
    m[1] = 8'h5;
    r = m[1];
  endtask
  initial t(o);
endmodule

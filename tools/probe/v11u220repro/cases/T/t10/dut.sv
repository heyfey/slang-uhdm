// § strLitShiftNeedsBacktick220
interface bus;
  string s;
  task automatic t();
    s = "i\tj";
  endtask
endinterface
module top;
  bus b();
  for (genvar g = 0; g < 2; g++) begin : gen
    string z;
    initial z = "g\\h";
  end
endmodule

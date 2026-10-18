// § subrBuiltinClassArrElemUnsup404
module top;
  task automatic t2;
    std::process q[] = new[2];
    process r;
    begin
      process z[4];
      $display(q.size(), $size(z));
    end
  endtask
  initial t2;
endmodule

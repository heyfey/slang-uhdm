// r10uvm57repro/a3_scope.sv -- the SAME declaration in an unnamed block at
// every scope the campaign cares about: initial, always, a package function, a
// module-level function, a module-level task.
package p3;
  function automatic int pf(int obj);
    pf = obj;
    if (obj == 0) begin
      string pmsg;
      pmsg = "pkg";
      $display(pmsg);
    end
  endfunction
endpackage

module a3_scope;
  logic clk;
  int q;

  function automatic int mf(int obj);
    mf = obj;
    if (obj == 0) begin
      string fmsg;
      fmsg = "modfunc";
      $display(fmsg);
    end
  endfunction

  task automatic mt(int obj);
    if (obj == 0) begin
      string tmsg;
      tmsg = "modtask";
      $display(tmsg);
    end
  endtask

  initial begin
    if (q == 0) begin
      string imsg;
      imsg = "initial";
      $display(imsg);
    end
  end

  always @(posedge clk) begin
    if (q == 1) begin
      string amsg;
      amsg = "always";
      $display(amsg);
    end
  end

  initial q = p3::pf(0) + mf(0);
endmodule

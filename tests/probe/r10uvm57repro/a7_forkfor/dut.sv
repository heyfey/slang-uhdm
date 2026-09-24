// r10uvm57repro/a7_forkfor.sv -- a fork/join block and a for-loop body block,
// each with a declaration.  slang wraps for-loops carrying inline declarations
// in an IMPLICIT block that Surelog has no wrapper for (grep ForLoopStatement
// in src/StmtEmit.cpp), so an over-fire would hide HERE.
class ff_c;
  static task t(int obj);
    fork
      begin
        string fmsg;
        fmsg = "fork";
        $display(fmsg);
      end
      begin
        string fmsg2;
        fmsg2 = "fork2";
        $display(fmsg2);
      end
    join
    for (int i = 0; i < 2; i++) begin
      string lmsg;
      lmsg = "loop";
      $display(lmsg, i);
    end
    while (obj > 0) begin
      string wmsg;
      wmsg = "while";
      $display(wmsg);
      obj = obj - 1;
    end
  endtask
endclass

module a7_forkfor;
  int n;
  initial begin
    fork
      begin
        string mf;
        mf = "mfork";
        $display(mf);
      end
    join
    for (int j = 0; j < 2; j++) begin
      string ml;
      ml = "mloop";
      $display(ml, j);
    end
  end
  ff_c fc;
  initial fc = null;
endmodule

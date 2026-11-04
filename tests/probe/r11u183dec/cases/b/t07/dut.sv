package p;
class item; endclass
class seqr #(type REQ=item, RSP=REQ);
  task run();
    REQ t;
    t = null;
  endtask
endclass
endpackage
module top; endmodule

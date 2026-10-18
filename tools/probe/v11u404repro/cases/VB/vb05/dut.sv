// § builtinClassElemNotInClass404v
class D;
  static task automatic st(int n);
    process r[] = new[n];
    $display(r.size());
  endtask
  task t2();
    mailbox m[$];
    $display(m.size());
  endtask
endclass
module top;
  initial begin D d = new; D::st(2); d.t2(); end
endmodule

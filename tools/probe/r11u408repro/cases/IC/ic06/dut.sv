// § ifaceClassNotListed408
interface class ia;
  pure virtual function void a();
endclass
interface class ib extends ia;
  pure virtual function void b();
endclass
class c implements ib;
  virtual function void a(); endfunction
  virtual function void b(); endfunction
endclass
module test;
  c h;
  ib r;
  initial begin
    h = new;
    r = h;
  end
endmodule

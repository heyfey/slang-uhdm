// § clsMethodOwnAutomatic462
module top;
  class C;
    task automatic t();
    endtask
    static task automatic s();
    endtask
    virtual function automatic void v();
    endfunction
  endclass
  C c;
endmodule

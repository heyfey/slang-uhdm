module ast84;
  class c84;
    string q[$];
    int    n;
    function void f();
      for (int i = 0; i < this.q.size(); i++) begin
        if (this.q[i] == "x")
          this.q.delete(i);
      end
      if (this.q.size() > 0) n = 1;
      n = this.n;
      this.q.push_back("y");
    endfunction
  endclass
endmodule

// § genScopeClassVarListed206 § foreachThisArrAtThisToken207 (a class declared in a generate block, its method iterating this.<array>, a variable of it in the scope)
module x02 ();
  if (1) begin : g
    class c;
      int arr [$];
      int fx [3];
      function void f();
        foreach (this.arr[i]) arr[i] = i;
        foreach (this.fx[k]) fx[k] = k;
      endfunction
    endclass
    c q;
  end
endmodule

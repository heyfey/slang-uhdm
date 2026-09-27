  class C #(type T = int);
    int n;
    task t();
      do begin
        T x;
        x = T::mk();
        n = n - 1;
      end while (n > 0);
    endtask
  endclass

import sample_pkg::*;
import pyhdl_if::*;

module top();
    sample_exp_impl python_caller;
    sample_impl sv_implementation;
    sample_imp_impl #(sample_impl) svdpi_caller;
    
    initial $display("%0t: Hello World from SV", $time);

    initial begin
        sv_implementation = new();
        svdpi_caller = new(sv_implementation);
        python_caller = new(svdpi_caller.m_obj);

        pyhdl_if::pyhdl_if_start();
        python_caller.hello_world_from_python();

        $finish;
    end

    

endmodule
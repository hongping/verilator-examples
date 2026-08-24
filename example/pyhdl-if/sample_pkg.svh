`include "pyhdl_if_macros.svh"
package sample_pkg;
    import pyhdl_if::*;
    interface class sample_exp_if;
        pure virtual task hello_world_from_python();
    endclass

    interface class sample_imp_if;
        pure virtual task delay(input longint cycle);
        pure virtual function longint get_sim_time();
    endclass

    class sample_exp_impl implements sample_exp_if;
        pyhdl_if::PyObject m_obj;
        function new(pyhdl_if::PyObject obj=null, bit create=1, string clsname="sample");
            m_obj = obj;
            if (create && (m_obj == null)) begin
                m_obj = create_pyobj();
                if (m_obj != null) begin
                    pyhdl_if::pyhdl_if_connectObject(m_obj, null);
                end
            end else begin
                m_obj = obj;
            end
        endfunction

        static function pyhdl_if::PyObject create_pyobj(string modname="sample", string clsname="sample");
            pyhdl_if::PyObject __args, __cls_m, __cls_t, __obj;
            pyhdl_if::PyGILState_STATE state = pyhdl_if::PyGILState_Ensure();
            __args = pyhdl_if::PyTuple_New(0);
            __cls_m = pyhdl_if::PyImport_ImportModule(modname);

            if (__cls_m == null) begin
                pyhdl_if::PyErr_Print();
                $display("Fatal Error: Failed to find module %%s", modname);
                $finish;
                pyhdl_if::PyGILState_Release(state);
                return null;
            end

            __cls_t = pyhdl_if::PyObject_GetAttrString(__cls_m, clsname);
            if (__cls_t == null) begin
                pyhdl_if::PyErr_Print();
                $display("Fatal Error: Failed to find class %%s", clsname);
                $finish;
                pyhdl_if::PyGILState_Release(state);
                return null;
            end

            __obj = pyhdl_if::PyObject_Call(__cls_t, __args, null);
            if (__obj == null) begin
                pyhdl_if::PyErr_Print();
                $display("Fatal Error: Failed to construct class sample");
                $finish;
                pyhdl_if::PyGILState_Release(state);
                return null;
            end

            pyhdl_if::PyGILState_Release(state);

            return __obj;
        endfunction


        virtual task hello_world_from_python();
            pyhdl_if::PyObject __res;
            pyhdl_if::PyGILState_STATE state = pyhdl_if::PyGILState_Ensure();
            pyhdl_if::PyObject __args = pyhdl_if::PyTuple_New(0);
            pyhdl_if::pyhdl_if_invokePyTask(__res, m_obj, "hello_world_from_python", __args);
            pyhdl_if::PyGILState_Release(state);
        endtask

        function void callpy();
            // Prepares arguments and calls Python object
        endfunction
    endclass

    class sample_imp_impl #(type ImpT=sample_imp_if) implements pyhdl_if::ICallApi;
        ImpT m_impl;
        PyObject m_obj;
        function new(ImpT impl, pyhdl_if::PyObject obj=null, bit create=1, string clsname="sample");
            m_impl = impl;
            if (obj == null && create) begin
                // Create an instance of the Python class
                m_obj = create_pyobj();
            end else begin
                m_obj = obj;
            end
            if (m_obj != null && m_impl != null) begin
                pyhdl_if::pyhdl_if_connectObject(m_obj, this);
            end
        endfunction

        static function pyhdl_if::PyObject create_pyobj(string modname="sample", string clsname="sample");
            pyhdl_if::PyObject __args, __cls_m, __cls_t, __obj;
            pyhdl_if::PyGILState_STATE state = pyhdl_if::PyGILState_Ensure();
            __args = pyhdl_if::PyTuple_New(0);
            __cls_m = pyhdl_if::PyImport_ImportModule(modname);

            if (__cls_m == null) begin
                pyhdl_if::PyErr_Print();
                $display("Fatal Error: Failed to find module %%s", modname);
                $finish;
                pyhdl_if::PyGILState_Release(state);
                return null;
            end

            __cls_t = pyhdl_if::PyObject_GetAttrString(__cls_m, clsname);
            if (__cls_t == null) begin
                pyhdl_if::PyErr_Print();
                $display("Fatal Error: Failed to find class %%s", clsname);
                $finish;
                pyhdl_if::PyGILState_Release(state);
                return null;
            end

            __obj = pyhdl_if::PyObject_Call(__cls_t, __args, null);
            if (__obj == null) begin
                pyhdl_if::PyErr_Print();
                $display("Fatal Error: Failed to construct class sample");
                $finish;
                pyhdl_if::PyGILState_Release(state);
                return null;
            end

            pyhdl_if::PyGILState_Release(state);

            return __obj;
        endfunction


        virtual function pyhdl_if::PyObject invokeFunc(string method, pyhdl_if::PyObject args);
            pyhdl_if::PyObject __ret = pyhdl_if::None;
            pyhdl_if::PyGILState_STATE state = pyhdl_if::PyGILState_Ensure();
            case (method)
                "get_sim_time": begin
                    longint __rval;
                    __rval = m_impl.get_sim_time();
                    __ret = pyhdl_if::PyLong_FromLong(__rval);
                end
                default: begin
                    $display("Fatal: unsupported method call %0s", method);
                end
            endcase
            pyhdl_if::PyGILState_Release(state);
            return __ret;
        endfunction

        virtual task invokeTask(
            output pyhdl_if::PyObject retval,
            inout pyhdl_if::PyGILState_STATE state,
            input string method,
            input pyhdl_if::PyObject args);
            retval = pyhdl_if::None;
            case (method)
                "delay": begin
                    longint __cycle = pyhdl_if::PyLong_AsLong(pyhdl_if::PyTuple_GetItem(args, 0));
                    pyhdl_if::PyGILState_Release(state); // Release the GIL before invoking the task
                    m_impl.delay(__cycle);
                    state = pyhdl_if::PyGILState_Ensure(); // Reacquire the GIL after invoking the task
                end
                default: begin
                    $display("Fatal: unsupported method call %0s", method);
                end
            endcase
        endtask
    endclass

endpackage

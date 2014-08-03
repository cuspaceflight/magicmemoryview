# Copyright 2014 (C) Adam Greig, Daniel Richman
#
# This file is part of Tawhiri.
#
# Tawhiri is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Tawhiri is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Tawhiri.  If not, see <http://www.gnu.org/licenses/>.


import struct

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free
from cpython.buffer cimport PyBUF_SIMPLE, Py_buffer
from cpython.buffer cimport PyObject_GetBuffer, PyBuffer_Release
cdef extern int PyObject_AsReadBuffer(object, const void **, Py_ssize_t *)


cdef class MagicMemoryView:
    IF PY2:
        cdef object buffer
    ELSE:
        cdef Py_buffer buffer
        cdef bint buffer_full

    cdef void* buf
    cdef Py_ssize_t len, itemsize
    cdef Py_ssize_t *shape
    cdef Py_ssize_t *strides
    cdef int ndim
    cdef object format

    def __cinit__(self):
        IF not PY2:
            self.buffer_full = False

    def __dealloc__(self):
        IF not PY2:
            if self.buffer_full:
                PyBuffer_Release(&self.buffer)

        PyMem_Free(self.shape)
        PyMem_Free(self.strides)

    def __init__(self, object buffer, object shape, object format):
        cdef Py_ssize_t acc, expect_length
        cdef int result

        self.ndim = len(shape)
        self.format = format
        self.itemsize = struct.calcsize(format)

        self.shape   = <Py_ssize_t *> PyMem_Malloc(self.ndim * sizeof(Py_ssize_t))
        self.strides = <Py_ssize_t *> PyMem_Malloc(self.ndim * sizeof(Py_ssize_t))

        if not self.shape or not self.strides:
            raise MemoryError()

        acc = self.itemsize
        for i in range(self.ndim - 1, 0, -1):
            self.shape[i] = shape[i]
            self.strides[i] = acc
            acc *= self.shape[i]

        expect_length = acc

        IF PY2:
            # need to hold a reference to the buffer, or it will be freed
            self.buffer = buffer

            cdef const void * cbuf
            result = PyObject_AsReadBuffer(buffer, &cbuf, &self.len)
            if result == 0:
                self.buf = <void*>cbuf
            else:
                raise RuntimeError("Could not get buffer from memmap.")
        ELSE:
            # The Py_Buffer struct contains a reference to the buffer.
            result = PyObject_GetBuffer(buffer, &self.buffer, PyBUF_SIMPLE)
            if result == 0:
                self.buffer_full = True
                self.buf = self.buffer.buf
                self.len = self.buffer.len
            else:
                raise RuntimeError("Could not get buffer from memmap.")

        if self.len != expect_length:
            raise ValueError("Buffer is wrong size: (got {0}, {1})"
                                 .format(self.len, expect_length))

    def __getbuffer__(object self, Py_buffer* view, int flags):
        view.buf = self.buf
        view.len = self.len
        view.shape = self.shape
        view.strides = self.strides
        view.readonly = 0
        view.format = self.format
        view.itemsize = self.itemsize
        view.ndim = self.ndim

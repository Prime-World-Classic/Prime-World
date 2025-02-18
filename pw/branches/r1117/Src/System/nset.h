#ifndef _NSET_H_
#define _NSET_H_
/*
 *
 * Copyright (c) 1994
 * Hewlett-Packard Company
 *
 * Copyright (c) 1996,1997
 * Silicon Graphics Computer Systems, Inc.
 *
 * Copyright (c) 1997
 * Moscow Center for SPARC Technology
 *
 * Copyright (c) 1999 
 * Boris Fomitchev
 *
 * This material is provided "as is", with absolutely no warranty expressed
 * or implied. Any use is at your own risk.
 *
 * Permission to use or copy this software for any purpose is hereby granted 
 * without fee, provided the above notices are retained on all copies.
 * Permission to modify the code and to distribute modified code is granted,
 * provided the above notices are retained, and a notice that the code was
 * modified is included with the above copyright notice.
 *
 */

/* NOTE: This is an internal header file, included by other STL headers.
 *	 You should not attempt to use it directly.
 */

#include "ntree.h"

namespace nstl
{

template <class _Arg, class _Result>
struct unary_function {
	typedef _Arg argument_type;
	typedef _Result result_type;
};

template <class _Tp>
struct _Identity : public unary_function<_Tp,_Tp> {
	const _Tp& operator()(const _Tp& __x) const { return __x; }
};

template < class _Key, class _Compare = less >
class set {
public:
// typedefs:
	typedef _Key		 key_type;
	typedef _Key		 value_type;
	typedef _Compare key_compare;
	typedef _Compare value_compare;
private:
	typedef _Rb_tree<key_type, value_type, _Identity<value_type>, key_compare/*, _Alloc*/> _Rep_type;
public:
	typedef typename _Rep_type::pointer pointer;
	typedef typename _Rep_type::const_pointer const_pointer;
	typedef typename _Rep_type::reference reference;
	typedef typename _Rep_type::const_reference const_reference;
	typedef typename _Rep_type::const_iterator const_iterator;
	typedef const_iterator iterator;
	typedef typename _Rep_type::const_reverse_iterator reverse_iterator;
	typedef typename _Rep_type::const_reverse_iterator const_reverse_iterator;
//	typedef typename _Rep_type::size_type size_type;
//	typedef typename _Rep_type::difference_type difference_type;
// typedef typename _Rep_type::allocator_type allocator_type;

private:
	_Rep_type _M_t;	// red-black tree representing set
public:

	// allocation/deallocation

	set() : _M_t(_Compare()/*, allocator_type()*/) {}
	explicit set(const _Compare& __comp
				 /*,const allocator_type& __a = allocator_type()*/)
		: _M_t(__comp/*, __a*/) {}

	set(const value_type* __first, const value_type* __last) 
		: _M_t(_Compare()/*, allocator_type()*/) 
		{ _M_t.insert_unique(__first, __last); }

	set(const value_type* __first, 
			const value_type* __last, const _Compare& __comp
			/*,const allocator_type& __a = allocator_type()*/)
		: _M_t(__comp/*, __a*/) { _M_t.insert_unique(__first, __last); }

	set(const_iterator __first, const_iterator __last)
		: _M_t(_Compare()/*, allocator_type()*/) 
		{ _M_t.insert_unique(__first, __last); }

	set(const_iterator __first, const_iterator __last, const _Compare& __comp
			/*,const allocator_type& __a = allocator_type()*/)
		: _M_t(__comp/*, __a*/) { _M_t.insert_unique(__first, __last); }

	set(const set<_Key,_Compare/*,_Alloc*/>& __x) : _M_t(__x._M_t) {}
	set<_Key,_Compare/*,_Alloc*/>& operator=(const set<_Key, _Compare/*, _Alloc*/>& __x)
	{ 
		_M_t = __x._M_t; 
		return *this;
	}

	// accessors:

	key_compare key_comp() const { return _M_t.key_comp(); }
	value_compare value_comp() const { return _M_t.key_comp(); }
//	allocator_type get_allocator() const { return _M_t.get_allocator(); }

	iterator begin() const { return _M_t.begin(); }
	iterator end() const { return _M_t.end(); }
	reverse_iterator rbegin() const { return _M_t.rbegin(); } 
	reverse_iterator rend() const { return _M_t.rend(); }
	bool empty() const { return _M_t.empty(); }
	int size() const { return _M_t.size(); }
	int max_size() const { return _M_t.max_size(); }
	void swap(set<_Key,_Compare/*,_Alloc*/>& __x) { _M_t.swap(__x._M_t); }

	// insert/erase
	pair<iterator,bool> insert(const value_type& __x) { 
		typedef typename _Rep_type::iterator _Rep_iterator;
		pair<_Rep_iterator, bool> __p = _M_t.insert_unique(__x); 
		return pair<iterator, bool>(reinterpret_cast<const iterator&>(__p.first), __p.second );
	}
	iterator insert(iterator __position, const value_type& __x) {
		typedef typename _Rep_type::iterator _Rep_iterator;
		return _M_t.insert_unique((_Rep_iterator&)__position, __x);
	}

	void insert(const_iterator __first, const_iterator __last) {
		_M_t.insert_unique(__first, __last);
	}
	void insert(const value_type* __first, const value_type* __last) {
		_M_t.insert_unique(__first, __last);
	}

	void erase(iterator __position) { 
		typedef typename _Rep_type::iterator _Rep_iterator;
		_M_t.erase((_Rep_iterator&)__position); 
	}
	int erase(const key_type& __x) { 
		return _M_t.erase(__x); 
	}
	void erase(iterator __first, iterator __last) { 
		typedef typename _Rep_type::iterator _Rep_iterator;
		_M_t.erase((_Rep_iterator&)__first, (_Rep_iterator&)__last); 
	}
	void clear() { _M_t.clear(); }
/*
	// set operations:
# if defined(_STLP_MEMBER_TEMPLATES) && ! defined ( _STLP_NO_EXTENSIONS )
	template <class _KT>
	iterator find(const _KT& __x) const { return _M_t.find(__x); }
# else
*/
	iterator find(const key_type& __x) const { return _M_t.find(__x); }
//# endif
	int count(const key_type& __x) const { 
		return _M_t.find(__x) == _M_t.end() ? 0 : 1 ; 
	}
	iterator lower_bound(const key_type& __x) const {
		return _M_t.lower_bound(__x);
	}
	iterator upper_bound(const key_type& __x) const {
		return _M_t.upper_bound(__x); 
	}
	pair<iterator,iterator> equal_range(const key_type& __x) const {
		return _M_t.equal_range(__x);
	}
};
/*
# define _STLP_TEMPLATE_HEADER template <class _Key, class _Compare, class _Alloc>
# define _STLP_TEMPLATE_CONTAINER set<_Key,_Compare,_Alloc>
# include <stl/_relops_cont.h>
# undef	_STLP_TEMPLATE_CONTAINER
# define _STLP_TEMPLATE_CONTAINER multiset<_Key,_Compare,_Alloc>
# include <stl/_relops_cont.h>
# undef	_STLP_TEMPLATE_CONTAINER
# undef	_STLP_TEMPLATE_HEADER
*/
}

// do a cleanup
# undef set
# undef multiset
// provide a way to access full funclionality 
//# define __set__	__FULL_NAME(set)
//# define __multiset__	__FULL_NAME(multiset)
/*
# ifdef _STLP_USE_WRAPPER_FOR_ALLOC_PARAM
# include <stl/wrappers/_set.h>
# endif
*/
//#endif /* _STLP_INTERNAL_SET_H */

// Local Variables:
// mode:C++
// End:

#endif // _NSET_H_


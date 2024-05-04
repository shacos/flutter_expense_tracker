import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/models/expense.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() {
    return _NewExpense();
  }
}

class _NewExpense extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickerDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );

    setState(() {
      _selectedDate = pickerDate;
    });
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
                title: const Text(
                  'Invalid Input.',
                ),
                content: const Text(
                  'Please insert a valid title, amount, date and category.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Okay',
                    ),
                  )
                ],
              ));
    } else {
      showDialog(
        context: context,
        builder: ((ctx) => AlertDialog(
              title: const Text(
                'Invalid Input.',
              ),
              content: const Text(
                'Please insert a valid title, amount, date and category.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Okay',
                  ),
                )
              ],
            )),
      );
    }
  }

  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text);
    final isAmountInvalid = enteredAmount == null || enteredAmount <= 0;
    if (_titleController.text.trim().isEmpty ||
        isAmountInvalid ||
        _selectedDate == null) {
      _showDialog();
      return;
    }

    widget.onAddExpense(
      Expense(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    final Widget titleWidget = TextField(
      controller: _titleController,
      maxLength: 50,
      decoration: const InputDecoration(
        label: Text(
          'Title',
        ),
      ),
    );

    final Widget amountWidget = Expanded(
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          prefixText: '\$ ',
          label: Text(
            'Amount',
          ),
        ),
      ),
    );

    final Widget dateWidget = Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _selectedDate == null
                ? 'No Date Selected'
                : formatter.format(_selectedDate!),
          ),
          IconButton(
            onPressed: _presentDatePicker,
            icon: const Icon(
              Icons.calendar_month_sharp,
            ),
          ),
        ],
      ),
    );

    final Widget dropdownButtonWidget = DropdownButton(
        value: _selectedCategory,
        items: Category.values
            .map(
              (category) => DropdownMenuItem(
                value: category,
                child: Text(
                  category.name.toUpperCase(),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) {
            return;
          }
          setState(() {
            _selectedCategory = value;
          });
        });

    final List<Widget> saveAndCancelButtons = [
      const Spacer(),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          'Cancel',
        ),
      ),
      ElevatedButton(
        onPressed: _submitExpenseData,
        child: const Text(
          'Save Expense',
        ),
      )
    ];

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final width = constraints.maxWidth;

        return SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
              child: Column(
                children: [
                  if (width >= 600)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: titleWidget),
                        const SizedBox(width: 24),
                        amountWidget,
                      ],
                    )
                  else
                    titleWidget,
                  if (width >= 600)
                    Row(
                      children: [
                        dropdownButtonWidget,
                        const SizedBox(width: 24),
                        dateWidget
                      ],
                    )
                  else
                    Row(
                        children: [
                          amountWidget,
                          const SizedBox(
                            width: 16,
                          ),
                          dateWidget,
                        ]),
                  const SizedBox(
                    height: 16,
                  ),
                  if (width >= 600)
                    Row(
                      children: saveAndCancelButtons,
                    )
                  else
                    Row(
                      children: [
                        dropdownButtonWidget,
                        ...saveAndCancelButtons,
                      ],
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

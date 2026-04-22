
"""
Test custom Django management commands.
"""
from unittest.mock import patch
from psycopg2 import OperationalError as Psycopg2Error
from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase
'''
patch is used generally to mock behaviour, here we
will mock the behavior of the database because we need to simulate when the
database is returning a response or not
'''

# from psycopg2 import OperationalError as Psycopg2Error
'''
One of the possibilities error that we might get when we
try and connect to database
'''

# from django.core.management import call_command
# This is a helper function provided by Django that allows us
# to simulate to actually call the command by the name

# from django.db.utils import OperationalError
# This error throws by Django when database is not ready

# from django.test import SimpleTestCase


@patch('core.management.commands.wait_for_db.Command.check')
class CommandTests(SimpleTestCase):
    """Test commands."""

    def test_wait_for_db_ready(self, patched_check):
        """Test waiting for database if database ready."""
        patched_check.return_value = True

        call_command('wait_for_db')

        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """Test waiting for database when getting OperationalError."""
        patched_check.side_effect = [Psycopg2Error] * 2 + \
            [OperationalError] * 3 + [True]

        call_command('wait_for_db')

        self.assertEqual(patched_check.call_count, 6)
        patched_check.assert_called_with(databases=['default'])

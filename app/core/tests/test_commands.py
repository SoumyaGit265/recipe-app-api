
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


@patch('django.db.utils.ConnectionHandler.__getitem__')
class CommandTests(SimpleTestCase):
    """Test commands."""

    def test_wait_for_db_ready(self, patched_getitem):
        """Test waiting for database if database ready."""
        patched_getitem.return_value = True

        call_command('wait_for_db')

        self.assertEqual(patched_getitem.call_count, 1)

    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_getitem):
        """Test waiting for database when getting OperationalError."""
        patched_getitem.side_effect = [Psycopg2Error] + \
            [OperationalError] * 5 + [True]

        call_command('wait_for_db')

        self.assertEqual(patched_getitem.call_count, 6)

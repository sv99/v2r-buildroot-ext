# coding: utf-8
from __future__ import unicode_literals, print_function, division, absolute_import

from sqlalchemy import create_engine
from sqlalchemy import Column, Integer, String, DateTime, Boolean

engine = create_engine('sqlite:db/messages.sqlite', echo=False)
from sqlalchemy.ext.declarative import declarative_base

__author__ = 'svolkov'

Base = declarative_base()


class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    username = Column(String(30), nullable=False)
    first_name = Column(String(30), nullable=False)
    last_name = Column(String(30), nullable=False)
    email = Column(String(75), nullable=False)
    password = Column(String(128), nullable=False)

    def __repr__(self):
        return "<User('%s')>" % self.username


users_table = User.__table__
metadata = Base.metadata


def create_all():
    metadata.create_all(engine)

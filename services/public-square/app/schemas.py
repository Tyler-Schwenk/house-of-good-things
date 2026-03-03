"""
Pydantic schemas for request/response validation.

Defines data structures for API endpoints and validation rules.
"""

from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import Optional


# User Schemas
class UserRead(BaseModel):
    """User data returned in API responses."""
    id: int
    email: str
    username: Optional[str] = None
    is_active: bool
    is_verified: bool
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class UserPublic(BaseModel):
    """Limited user data for public display (e.g., in posts/comments)."""
    id: int
    username: Optional[str] = None
    
    model_config = ConfigDict(from_attributes=True)


# Post Schemas
class PostBase(BaseModel):
    """Base post fields for creation and updates."""
    title: str = Field(..., min_length=1, max_length=200, description="Post title")
    content: str = Field(..., min_length=1, max_length=50000, description="Post content")
    is_published: bool = Field(default=True, description="Whether post is visible")


class PostCreate(PostBase):
    """Schema for creating a new post."""
    pass


class PostUpdate(BaseModel):
    """Schema for updating an existing post. All fields optional."""
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    content: Optional[str] = Field(None, min_length=1, max_length=50000)
    is_published: Optional[bool] = None


class PostRead(PostBase):
    """Post data returned in API responses."""
    id: int
    author_id: int
    author: UserPublic
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    model_config = ConfigDict(from_attributes=True)


class PostList(BaseModel):
    """Paginated list of posts."""
    posts: list[PostRead]
    total: int
    page: int
    page_size: int
    total_pages: int


# Comment Schemas
class CommentBase(BaseModel):
    """Base comment fields for creation and updates."""
    content: str = Field(..., min_length=1, max_length=10000, description="Comment content")


class CommentCreate(CommentBase):
    """Schema for creating a new comment."""
    pass


class CommentUpdate(BaseModel):
    """Schema for updating an existing comment."""
    content: str = Field(..., min_length=1, max_length=10000)


class CommentRead(CommentBase):
    """Comment data returned in API responses."""
    id: int
    post_id: int
    author_id: int
    author: UserPublic
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    model_config = ConfigDict(from_attributes=True)


# Health Check Schema
class HealthCheck(BaseModel):
    """Health check response."""
    status: str = "healthy"
    version: str
    timestamp: datetime

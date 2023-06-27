use postgresql_reducer::ObjectTypeName;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub enum UserStatus {
    New,
    GoodStanding,
    Suspended,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    pub name: Option<String>,
    pub status: UserStatus,
    pub offers: Vec<String>,
}

impl ObjectTypeName for User {
    fn type_name() -> &'static str {
        "user"
    }
}

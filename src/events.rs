use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", content = "data")]
pub enum Event {
    UserCreated {
        user_id: String,
    },
    UserNameUpdated {
        user_id: String,
        name: Option<String>,
    },
    UserDeleted {
        user_id: String,
    },
    SomeOtherEvent {},
}
